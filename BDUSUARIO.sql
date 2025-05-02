USE [DB_INMOBISOFT_2]
GO
/****** Object:  StoredProcedure [bancos].[pa_operacion_bancaria]    Script Date: 02/05/2025 18:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Author:		Mario Robles
-- Create date: 2024/06/18
-- Description:	Obtener todas las operaciones bancarias
ALTER PROCEDURE [bancos].[pa_operacion_bancaria] -- EXEC [bancos].[pa_operacion_bancaria] 1, 5
	@nIdUsuario INT,
	@nIdCompania INT
AS
BEGIN
	SELECT
		OB.nIdOperacionBancaria
		,P.nIdProyecto
		,P.sNombre AS sProyecto
		,OB.nIdCuenta
		,C.sNroCuenta
		,OB.nIdMoneda
		,M.sMoneda
		,M.sSimbolo
		,OB.sReferencia
		,OB.nMovimiento
		,OB.dFechaOperacion
		,OB.nImporte
		,OB.nITF
		,OB.nSaldo
		,OB.nIdEstado
		,E.sAbrev AS sEstado
		,OB.nIdAdjunto
		,A.sRutaFtp
		,OB.nIdUsuario_crea
		,OB.dFecha_crea
		,OB.nIdUsuario_mod
		,OB.dFecha_mod
	FROM
		bancos.Operacion_Bancaria OB
		INNER JOIN
		bancos.Cuenta C ON C.nIdCuenta = OB.nIdCuenta
		INNER JOIN
		maestros.Moneda M ON M.nIdMoneda = OB.nIdMoneda
		INNER JOIN
		proyectos.Proyecto P ON P.nIdProyecto = C.nIdProyecto
		INNER JOIN
		maestros.Elemento_Sistema E ON E.nIdElemento = OB.nIdEstado
		LEFT JOIN
		maestros.Adjunto A ON A.nIdAdjunto = OB.nIdAdjunto
	WHERE
		P.nIdCompania = @nIdCompania
END

GO
/****** Object:  NumberedStoredProcedure [bancos].[pa_operacion_bancaria];2    Script Date: 02/05/2025 18:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Author:		Mario Robles
-- Create date: 2024/06/18
-- Description:	Obtener todos los proyectos disponibles de una compania
ALTER PROCEDURE [bancos].[pa_operacion_bancaria];2  -- EXEC [bancos].[pa_operacion_bancaria];2 1, 5
	@nIdUsuario INT,
	@nIdCompania INT
AS
BEGIN
	SELECT
		nIdProyecto AS nCod
		,sDescripcion AS sDesc
	FROM
		proyectos.Proyecto
	WHERE
		nIdCompania = @nIdCompania	
END

GO
/****** Object:  NumberedStoredProcedure [bancos].[pa_operacion_bancaria];3    Script Date: 02/05/2025 18:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Author:		Mario Robles
-- Create date: 2024/06/18
-- Description:	Obtener todos las cuentas disponibles de un proyecto
ALTER PROCEDURE [bancos].[pa_operacion_bancaria];3 -- EXEC [bancos].[pa_operacion_bancaria];3 1, 5, 7
	@nIdUsuario INT,
	@nIdCompania INT,
	@nIdProyecto INT,
	@nIdMoneda INT
AS
BEGIN
	IF(@nIdMoneda IS NULL)
	BEGIN
		SELECT
			C.nIdCuenta
			,C.nIdBanco
			,B.sBanco
			,C.nIdMoneda
			,M.sMoneda
			,M.sSimbolo
			,C.nIdProyecto
			,C.sNroCuenta
			,C.bActivo
			,C.nIdUsuario_crea
			,C.dFecha_crea
		FROM
			bancos.Cuenta C
			INNER JOIN
			bancos.Banco B ON B.nIdBanco = C.nIdBanco
			INNER JOIN
			maestros.Moneda M ON M.nIdMoneda = C.nIdMoneda
		WHERE
			C.bActivo = 1
			AND
			C.nIdProyecto = @nIdProyecto	
	END
	ELSE
	BEGIN
		SELECT
			C.nIdCuenta
			,C.nIdBanco
			,B.sBanco
			,C.nIdMoneda
			,M.sMoneda
			,M.sSimbolo
			,C.nIdProyecto
			,C.sNroCuenta
			,C.bActivo
			,C.nIdUsuario_crea
			,C.dFecha_crea
		FROM
			bancos.Cuenta C
			INNER JOIN
			bancos.Banco B ON B.nIdBanco = C.nIdBanco
			INNER JOIN
			maestros.Moneda M ON M.nIdMoneda = C.nIdMoneda
		WHERE
			C.bActivo = 1
			AND
			C.nIdProyecto = @nIdProyecto	
			AND
			C.nIdMoneda = @nIdMoneda
	END
END

GO
/****** Object:  NumberedStoredProcedure [bancos].[pa_operacion_bancaria];4    Script Date: 02/05/2025 18:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Author:		Mario Robles
-- Create date: 2024/06/18
-- Description:	INSERTAR OPERACION BANCARIA
ALTER PROCEDURE [bancos].[pa_operacion_bancaria];4 -- EXEC [bancos].[pa_operacion_bancaria];4
	@nIdCuenta INT,
	@sReferencia VARCHAR(200),
	@nMovimiento INT,
	@dFechaOperacion DATE,
	@nImporte DECIMAL(13,4),
	@nITF DECIMAL(13,4),
	@nIdUsuario_crea INT,
	@nIdCompania INT
AS
BEGIN
	DECLARE @nCod INT, @sMsj VARCHAR(MAX)
	DECLARE @bValido BIT = 1
	DECLARE @nCant INT

	SELECT @nCant = COUNT(*) FROM bancos.Cuenta WHERE nIdCuenta = @nIdCuenta AND bActivo = 1

	IF(@nCant < 1)
	BEGIN
		SET @bValido = 0
		SET @nCod = 0
		SET @sMsj = 'La cuenta indicada no está registrada o no está activa en el sistema.'
	END

	IF(@bValido = 1)
	BEGIN
		SELECT @nCant = COUNT(*) FROM bancos.Operacion_Bancaria WHERE nIdCuenta = @nIdCuenta AND nMovimiento = @nMovimiento

		IF(@nCant > 0)
		BEGIN
			SET @bValido = 0
			SET @nCod = 0
			SET @sMsj = 'Ya operación bancaria registrada con ese Nro Movimiento para esa cuenta.'
		END
	END

	IF(@bValido = 1)
	BEGIN
		BEGIN TRANSACTION InsOperacionBancaria
  		BEGIN TRY 
		
			INSERT INTO bancos.Operacion_Bancaria
			(
				nIdCuenta
				,nIdMoneda
				,sReferencia
				,nMovimiento
				,dFechaOperacion
				,nImporte
				,nITF
				,nSaldo
				,nIdEstado
				,nIdUsuario_crea
				,dFecha_crea
			)
			VALUES
			(
				@nIdCuenta
				,(SELECT nIdMoneda FROM bancos.Cuenta WHERE nIdCuenta = @nIdCuenta)
				,@sReferencia
				,@nMovimiento
				,@dFechaOperacion
				,@nImporte
				,@nITF
				,@nImporte
				,(SELECT nIdElemento FROM maestros.Elemento_Sistema WHERE nIdElementoP = (SELECT ES.nIdElemento FROM maestros.Elemento_Sistema ES WHERE ES.sCodigo = 'ESTOPEBAN') AND sCodigo = '1')
				,@nIdUsuario_crea
				,GETDATE()
			)

			SELECT @nCod = scope_identity()
			SET @sMsj = 'Operacion bancaria registrada.'

		END TRY
		BEGIN CATCH
			SET @nCod = 0;
			SELECT @sMsj = ERROR_MESSAGE()  

			IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION InsOperacionBancaria;  
		END CATCH

		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION InsOperacionBancaria;  
	END

	SELECT @nCod AS nCod, @sMsj AS sMsj
END

GO
/****** Object:  NumberedStoredProcedure [bancos].[pa_operacion_bancaria];5    Script Date: 02/05/2025 18:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Author:		Mario Robles
-- Create date: 2024/06/18
-- Description:	ACTUALIZAR OPERACION BANCARIA
ALTER PROCEDURE [bancos].[pa_operacion_bancaria];5 -- EXEC [bancos].[pa_operacion_bancaria];5
	@nIdOperacionBancaria INT,
	@sReferencia VARCHAR(200),
	@dFechaOperacion DATE,
	@nIdEstado INT,
	@nIdAdjunto INT,
	@nIdUsuario_mod INT,
	@nIdCompania INT
AS
BEGIN
	DECLARE @nCod INT, @sMsj VARCHAR(MAX)
	DECLARE @bValido BIT = 1
	DECLARE @nCant INT

	SELECT @nCant = COUNT(*) FROM bancos.Operacion_Bancaria WHERE nIdOperacionBancaria = @nIdOperacionBancaria

	IF(@nCant = 0)
	BEGIN
		SET @bValido = 0
		SET @nCod = 0
		SET @sMsj = 'La operacion bancaria indicada no existe.'
	END
	
	IF(@bValido = 1)
	BEGIN
		BEGIN TRANSACTION UpdOperacionBancaria
  		BEGIN TRY 
		
			UPDATE bancos.Operacion_Bancaria
			SET
				sReferencia = @sReferencia
				,dFechaOperacion = @dFechaOperacion
				,nIdEstado = @nIdEstado
				,nIdUsuario_mod = @nIdUsuario_mod
				,dFecha_mod = GETDATE()
			WHERE
				nIdOperacionBancaria = @nIdOperacionBancaria

			SELECT @nCod = @nIdOperacionBancaria
			SET @sMsj = 'Operacion bancaria actualizada.'

		END TRY
		BEGIN CATCH
			SET @nCod = 0;
			SELECT @sMsj = ERROR_MESSAGE()  

			IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION UpdOperacionBancaria;  
		END CATCH

		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION UpdOperacionBancaria;  
	END

	SELECT @nCod AS nCod, @sMsj AS sMsj
END

GO
/****** Object:  NumberedStoredProcedure [bancos].[pa_operacion_bancaria];6    Script Date: 02/05/2025 18:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Author:		Mario Robles
-- Create date: 2024/06/18
-- Description:	BUSCAR OPERACION BANCARIA BY CUENTA Y MOVIMIENTO
ALTER PROCEDURE [bancos].[pa_operacion_bancaria];6 -- EXEC [bancos].[pa_operacion_bancaria];6 5, 1, 1, 1001
	@nIdCompania INT,
	@nIdUsuario INT,
	@nIdCuenta INT,
	@nMovimiento INT
AS
BEGIN
	SELECT
		OB.nIdOperacionBancaria
		,P.nIdProyecto
		,P.sNombre AS sProyecto
		,OB.nIdCuenta
		,C.sNroCuenta
		,OB.nIdMoneda
		,M.sMoneda
		,M.sSimbolo
		,OB.sReferencia
		,OB.nMovimiento
		,OB.dFechaOperacion
		,OB.nImporte
		,OB.nITF
		,OB.nSaldo
		,OB.nIdEstado
		,E.sAbrev AS sEstado
		,OB.nIdAdjunto
		,A.sRutaFtp
		,OB.nIdUsuario_crea
		,OB.dFecha_crea
		,OB.nIdUsuario_mod
		,OB.dFecha_mod
	FROM
		bancos.Operacion_Bancaria OB
		INNER JOIN
		bancos.Cuenta C ON C.nIdCuenta = OB.nIdCuenta
		INNER JOIN
		maestros.Moneda M ON M.nIdMoneda = OB.nIdMoneda
		INNER JOIN
		proyectos.Proyecto P ON P.nIdProyecto = C.nIdProyecto
		INNER JOIN
		maestros.Elemento_Sistema E ON E.nIdElemento = OB.nIdEstado
		LEFT JOIN
		maestros.Adjunto A ON A.nIdAdjunto = OB.nIdAdjunto
	WHERE
		OB.nIdCuenta = @nIdCuenta
		AND
		OB.nMovimiento = @nMovimiento
END

GO
/****** Object:  NumberedStoredProcedure [bancos].[pa_operacion_bancaria];7    Script Date: 02/05/2025 18:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Author:		Mario Robles
-- Create date: 2024/09/26
-- Description:	INSERTAR OPERACION BANCARIA RECAUDO BBVA
ALTER PROCEDURE [bancos].[pa_operacion_bancaria];7 -- EXEC [bancos].[pa_operacion_bancaria];7
	@nConvenio INT
	,@sReferencia VARCHAR(200)
	,@nMovimiento INT
	,@dFechaOperacion DATE
	,@nImporte DECIMAL(13,4)
	,@nIdOrdenPago INT
	,@nIdCronograma INT
AS
BEGIN
	DECLARE @Results TABLE (nCod INT, sMsj VARCHAR(MAX));

	DECLARE @nIdCuenta INT
	DECLARE @nIdCompania INT
	DECLARE @nIdUsuario_crea INT = 1

	DECLARE @nCod INT = 0, @sMsj VARCHAR(MAX)

	SELECT
		@nIdCuenta = C.nIdCuenta
		,@nIdCompania = P.nIdCompania
	FROM
		bancos.Cuenta C
		INNER JOIN
		proyectos.Proyecto P ON P.nIdProyecto = C.nIdProyecto
	WHERE 
		nConvenio = @nConvenio

	INSERT INTO @Results
	EXEC [bancos].[pa_operacion_bancaria];4 @nIdCuenta, @sReferencia, @nMovimiento, @dFechaOperacion, @nImporte, null, @nIdUsuario_crea, @nIdCompania

	SELECT TOP 1 @nCod = nCod, @sMsj = sMsj FROM @Results
	DELETE FROM @Results

	IF(@nCod > 0)
	BEGIN
		IF(@nIdOrdenPago IS NOT NULL)
		BEGIN
			BEGIN TRANSACTION UpdOrdenPago
  			BEGIN TRY 
				UPDATE
					contabilidad.Orden_Pago
				SET
					dFechaVencimiento = DATEADD(MINUTE, 30, dFechaVencimiento)
					,nIdEstado = (SELECT E.nIdElemento FROM maestros.Elemento_Sistema E INNER JOIN maestros.Elemento_Sistema EP ON EP.nIdElemento = E.nIdElementoP WHERE EP.sCodigo = 'ESTORDPAG' AND E.sCodigo = '2')
				WHERE
					nIdOrdenPago = @nIdOrdenPago

				SELECT @nCod = @nIdOrdenPago
				SET @sMsj = 'Orden pago extendida.'

			END TRY
			BEGIN CATCH
				SET @nCod = 0;
				SELECT @sMsj = ERROR_MESSAGE()  

				IF @@TRANCOUNT > 0  
					ROLLBACK TRANSACTION UpdOrdenPago;  
			END CATCH

			IF @@TRANCOUNT > 0  
				COMMIT TRANSACTION UpdOrdenPago;
		END

		IF(@nIdCronograma IS NOT NULL)
		BEGIN
			BEGIN TRANSACTION UpdCronograma
  			BEGIN TRY 
				UPDATE
					contratos.Cronograma
				SET
					dFechaPago = GETDATE()
					,nIdEstado = (SELECT E.nIdElemento FROM maestros.Elemento_Sistema E INNER JOIN maestros.Elemento_Sistema EP ON EP.nIdElemento = E.nIdElementoP WHERE EP.sCodigo = 'ESTCRONOG' AND E.sCodigo = '2')
				WHERE
					nIdCronograma = @nIdCronograma

				SELECT @nCod = @nIdCronograma
				SET @sMsj = 'Cronograma pagado.'
				
			END TRY
			BEGIN CATCH
				SET @nCod = 0;
				SELECT @sMsj = ERROR_MESSAGE()  

				IF @@TRANCOUNT > 0  
					ROLLBACK TRANSACTION UpdCronograma;  
			END CATCH

			IF @@TRANCOUNT > 0  
				COMMIT TRANSACTION UpdCronograma;
		END
	END

	SELECT @nCod AS nCod, @sMsj AS sMsj
END

GO
/****** Object:  NumberedStoredProcedure [bancos].[pa_operacion_bancaria];8    Script Date: 02/05/2025 18:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Author:		Mario Robles
-- Create date: 2024/06/18
-- Description:	Obtener todas las operaciones bancarias disponibles por recaudo 
ALTER PROCEDURE [bancos].[pa_operacion_bancaria];8 -- EXEC [bancos].[pa_operacion_bancaria];8
AS
BEGIN
	SELECT
		OB.nIdOperacionBancaria
		,P.nIdProyecto
		,P.sNombre AS sProyecto
		,OB.nIdCuenta
		,C.sNroCuenta
		,OB.nIdMoneda
		,M.sMoneda
		,M.sSimbolo
		,OB.sReferencia
		,OB.nMovimiento
		,OB.dFechaOperacion
		,OB.nImporte
		,OB.nITF
		,OB.nSaldo
		,OB.nIdEstado
		,E.sAbrev AS sEstado
		,OB.nIdAdjunto
		,A.sRutaFtp
		,OB.nIdUsuario_crea
		,OB.dFecha_crea
		,OB.nIdUsuario_mod
		,OB.dFecha_mod
	FROM
		bancos.Operacion_Bancaria OB
		INNER JOIN
		bancos.Cuenta C ON C.nIdCuenta = OB.nIdCuenta
		INNER JOIN
		maestros.Moneda M ON M.nIdMoneda = OB.nIdMoneda
		INNER JOIN
		proyectos.Proyecto P ON P.nIdProyecto = C.nIdProyecto
		INNER JOIN
		maestros.Elemento_Sistema E ON E.nIdElemento = OB.nIdEstado
		LEFT JOIN
		maestros.Adjunto A ON A.nIdAdjunto = OB.nIdAdjunto
	WHERE
		(
			OB.sReferencia LIKE 'OPV2%'
			OR
			OB.sReferencia LIKE 'CRO2%'
		)
		AND
			OB.nImporte = OB.nSaldo
		AND
			E.sCodigo = '1'
END

GO
/****** Object:  NumberedStoredProcedure [bancos].[pa_operacion_bancaria];9    Script Date: 02/05/2025 18:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Author:		Mario Robles
-- Create date: 2024/06/18
-- Description:	CONSUMIR OPERACION BANCARIA RECAUDO BBVA
ALTER PROCEDURE [bancos].[pa_operacion_bancaria];9 -- EXEC [bancos].[pa_operacion_bancaria];9 23776, NULL, 19638
	@nIdOperacionBancaria INT
	,@nIdOrdenPago INT
	,@nIdCronograma INT
AS
BEGIN
	DECLARE @nCod INT = 0, @sMsj VARCHAR(MAX)
	DECLARE @bValido BIT = 1
	DECLARE @nCant INT

	DECLARE @nIdMoneda			INT
	DECLARE @sReferencia		VARCHAR(MAX)
	DECLARE @nMovimiento		INT
	DECLARE @nImporte			DECIMAL(13,4)
	DECLARE @nSaldo				DECIMAL(13,4)
	DECLARE @dFechaOperacion	DATE

	DECLARE @nIdCliente			INT
	DECLARE @nIdCompania		INT
	DECLARE @nIdProyecto		INT
	DECLARE @nIdLote			INT
	DECLARE @nIdReserva			INT
	DECLARE @nIdContrato		INT
	DECLARE @nIdMonedaCrono		INT
	DECLARE @nImporteCrono		DECIMAL(13,4)

	DECLARE @nIdMonedaOrdenP	INT
	DECLARE @nImporteOrdenP		DECIMAL(13,4)
	DECLARE @nImporteSubTotalOP	DECIMAL(13,4)
	DECLARE @nImporteIGVOP		DECIMAL(13,4)

	DECLARE @nIdMedioPago		INT

	DECLARE @bIGV				BIT
	DECLARE @sTipoIGVnoAplicado VARCHAR(MAX)
	DECLARE @nIdTipoComprobante	INT

	DECLARE @sDescripcion VARCHAR(MAX)

	DECLARE @nIdUsuario_crea	INT

	SELECT @nIdUsuario_crea = nIdUsuario FROM seguridad.Usuario WHERE sUsuario = 'botemision'	
	SELECT @nIdMedioPago = E.nIdElemento FROM maestros.Elemento_Sistema E INNER JOIN maestros.Elemento_Sistema EP ON EP.nIdElemento = E.nIdElementoP  WHERE EP.sCodigo = 'TIPMEDPAG' AND E.sCodigo= '3'

	SELECT
		@nIdMoneda = OB.nIdMoneda
		,@sReferencia = OB.sReferencia
		,@nImporte = OB.nImporte
		,@nSaldo = OB.nSaldo
		,@nMovimiento = OB.nMovimiento
		,@dFechaOperacion = OB.dFechaOperacion
	FROM
		bancos.Operacion_Bancaria OB
		INNER JOIN
		maestros.Elemento_Sistema E ON E.nIdElemento = OB.nIdEstado
	WHERE
		OB.nIdOperacionBancaria = @nIdOperacionBancaria
		AND
		E.sCodigo = '1'
		AND
		OB.nImporte = OB.nSaldo
		--AND
		--OB.sReferencia LIKE IIF(@nIdOrdenPago IS NOT NULL, CONCAT('OPV2-', @nIdOrdenPago), CONCAT('CRO2-', @nIdCronograma,'-%'))

	IF(@sReferencia IS NULL)
	BEGIN
		SET @bValido = 0
		SET @nCod = 0
		SET @sMsj = 'OPERACION BANCARIA NO PUEDE SER UTILIZADA'
	END

	IF(@bValido = 1)
	BEGIN
		BEGIN TRANSACTION ConsumirOperacionBancaria
  		BEGIN TRY 
				IF(@nIdCronograma IS NOT NULL)
				BEGIN
					DECLARE @sTerminologia VARCHAR(MAX)
					DECLARE @sProyecto VARCHAR(MAX)
					DECLARE @sManzana VARCHAR(MAX)
					DECLARE @sLote VARCHAR(MAX)
					DECLARE @nNroCuota INT

					SELECT
						@nIdCliente = CTR.nIdCliente
						,@nIdContrato = CTR.nIdContrato
						,@nIdMonedaCrono = CRO.nIdMoneda
						,@nImporteCrono = CRO.nMontoFinal
						,@sProyecto = P.sDescripcion
						,@nIdCompania = P.nIdCompania
						,@nIdProyecto = P.nIdProyecto
						,@sManzana = M.sManzana
						,@nIdLote = L.nIdLote
						,@sLote = L.sLote
						,@nNroCuota = CRO.nNroCuota
					FROM
						contratos.Cronograma CRO
						INNER JOIN
						contratos.Contrato CTR ON CTR.nIdContrato = CRO.nIdContrato
						INNER JOIN
						proyectos.Lote L ON L.nIdLote = CTR.nIdLote
						INNER JOIN
						proyectos.Manzana M ON M.nIdManzana = L.nIdManzana
						INNER JOIN
						proyectos.Sector S ON S.nIdSector = M.nIdSector
						INNER JOIN
						proyectos.Proyecto P ON P.nIdProyecto = S.nIdProyecto
					WHERE
						CRO.nIdCronograma = @nIdCronograma

					SELECT @sTerminologia = sTerminologia FROM maestros.Item_Compania WHERE nIdCompania = @nIdCompania AND nIdItem = 11
					SET @sDescripcion = CONCAT('Proyecto: ', @sProyecto
										, '#n#', ISNULL(@sTerminologia,'Pago de cuotas')
										, '#n#Cuota N°: ', CONVERT(VARCHAR(MAX), @nNroCuota)
										, '#n#Cuota de MZ ', @sManzana, ' - LT ', @sLote
										, '#n#Forma de pago: Abono Bancario'
										, '#n#N° Operacion: ', @nMovimiento
										, '#n#Fecha Operacion: ', CONVERT(VARCHAR, @dFechaOperacion, 105)
										)

					DECLARE @sIdTipoComprobante VARCHAR(MAX)
					
					SELECT
						@bIGV = C.bImpuestoVenta
						,@sTipoIGVnoAplicado = C.sCodTipoIGV
						,@sIdTipoComprobante = CC.sIdTipoComprobanteMedioPago
					FROM
						proyectos.Proyecto P
						INNER JOIN
						comercial.Configuracion C ON C.nIdProyecto = P.nIdProyecto 
						INNER JOIN
						comercial.Configuracion_Concepto CC ON CC.nIdConfiguracion = C.nIdConfiguracion
					WHERE
						P.nIdProyecto = @nIdProyecto
						AND
						CC.nIdConceptoVenta = 11 

					SELECT TOP 1 @nIdTipoComprobante = nIdElemento
					FROM OPENJSON(CONVERT(VARCHAR(MAX), @sIdTipoComprobante))
					WITH(
						nIdElemento INT '$.nIdElemento'
						,bSeleccionado BIT '$.seleccionado'
					) 
					WHERE
						bSeleccionado = 1

					INSERT INTO contabilidad.Orden_Pago
					(
						nIdCliente
						,nIdMoneda
						,nIdEstado
						,nIdCompania
						,nIdTipoComprobante
						,nIdProyecto
						,nIdLote
						,nIdContrato
						,dFechaVencimiento
						,nIdUsuario_crea
						,dFecha_crea
					)
					VALUES
					(
						@nIdCliente
						,@nIdMonedaCrono
						,(
							SELECT
								E.nIdElemento 
							FROM 
								maestros.Elemento_Sistema E
								INNER JOIN
								maestros.Elemento_Sistema EP ON EP.nIdElemento = E.nIdElementoP
							WHERE
								EP.sCodigo = 'ESTORDPAG'
								AND
								E.sCodigo = '1'
						)
						,@nIdCompania
						,@nIdTipoComprobante
						,@nIdProyecto
						,@nIdLote
						,@nIdContrato
						,DATEADD(HOUR, 2, GETDATE())
						,@nIdUsuario_crea
						,GETDATE()
					)

					SELECT @nIdOrdenPago = scope_identity()

					INSERT INTO contabilidad.Orden_Pago_Det
					(
						nIdOrdenPago
						,nIdItem
						,sDescripcion
						,nCantidad
						,nValorUnitario
						,nValorSubtotal
						,nValorIgv
						,nValorTotal
						,nIdCronograma
					)
					VALUES
					(
						@nIdOrdenPago
						,11
						,@sDescripcion
						,1
						,@nImporteCrono
						,IIF(@bIGV = 1, (@nImporteCrono*100)/118, @nImporteCrono)
						,IIF(@bIGV = 1, (@nImporteCrono*18)/118, @nImporteCrono)
						,@nImporteCrono
						,@nIdCronograma
					)
				END

				SELECT
					@nIdCliente				= OP.nIdCliente
					,@nIdTipoComprobante	= OP.nIdTipoComprobante
					,@nIdMonedaOrdenP		= OP.nIdMoneda
					,@nIdCompania			= OP.nIdCompania
					,@nIdProyecto			= OP.nIdProyecto
					,@nIdReserva			= OP.nIdReserva
					,@nIdContrato			= OP.nIdContrato
					,@nImporteOrdenP		= SUM(OPD.nValorTotal)
					,@nImporteSubTotalOP	= SUM(OPD.nValorSubtotal)
					,@nImporteIGVOP			= SUM(OPD.nValorIgv)
				FROM
					contabilidad.Orden_Pago OP
					INNER JOIN
					contabilidad.Orden_Pago_Det OPD ON OPD.nIdOrdenPago = OP.nIdOrdenPago
				WHERE
					OP.nIdOrdenPago = @nIdOrdenPago
				GROUP BY
					OP.nIdCliente
					,OP.nIdTipoComprobante
					,OP.nIdMoneda
					,OP.nIdCompania
					,OP.nIdProyecto
					,OP.nIdReserva
					,OP.nIdContrato
				
				SELECT
					@bIGV = C.bImpuestoVenta
					,@sTipoIGVnoAplicado = C.sCodTipoIGV
				FROM
					comercial.Configuracion C
				WHERE
					C.nIdProyecto = @nIdProyecto

				DECLARE @sDNI				VARCHAR(MAX)
				DECLARE @sCE				VARCHAR(MAX)
				DECLARE @sRUC				VARCHAR(MAX)
				DECLARE @sNombreCompleto	VARCHAR(MAX)
				DECLARE @sDireccion			VARCHAR(MAX)
				DECLARE @sUbigeo			VARCHAR(MAX)

				SELECT
					@sDNI				= P.sDNI
					,@sCE				= P.sCE
					,@sRUC				= P.sRUC
					,@sNombreCompleto	= P.sNombreCompleto
					,@sDireccion		= D.sDireccion
					,@sUbigeo			= U.sUbigeo
				FROM
					comercial.Cliente C
					INNER JOIN 
					maestros.Persona P ON P.nIdPersona = C.nIdPersona
					INNER JOIN
					maestros.Direccion D ON D.nIdPersona = C.nIdPersona AND D.bPrincipal = 1
					INNER JOIN
					maestros.Ubigeo U ON U.nIdUbigeo = D.nIdUbigeo
				WHERE
					C.nIdCliente = @nIdCliente

				EXEC [contabilidad].[pa_cobranza] @nIdCliente, @nIdCompania, @nIdUsuario_crea, @bValido = @bValido OUTPUT, @nCod = @nCod OUTPUT, @sMsj = @sMsj OUTPUT

				IF (@bValido = 1)
				BEGIN					
					DECLARE @nIdCobranza INT
					SET @nIdCobranza = @nCod

					EXEC [contabilidad].[pa_cobranza];2 @nCod, @nIdMedioPago, @nIdOperacionBancaria, NULL, @nImporteOrdenP, @nIdMoneda, @nIdUsuario_crea, @bValido = @bValido OUTPUT, @nCod = @nCod OUTPUT, @sMsj = @sMsj OUTPUT

					IF (@bValido = 1)
					BEGIN
						UPDATE bancos.Operacion_Bancaria
						SET
								nSaldo = nSaldo - @nImporteOrdenP
								,nIdEstado = (
												SELECT nIdElemento FROM maestros.Elemento_Sistema
												WHERE		nIdElementoP = (SELECT nIdElemento FROM maestros.Elemento_Sistema WHERE sCodigo = 'ESTOPEBAN')
												AND sCodigo = '2'
								)
						WHERE
							nIdOperacionBancaria = @nIdOperacionBancaria

						UPDATE contabilidad.Orden_Pago
						SET
							nIdEstado = (
								SELECT TOP 1
									nIdElemento
								FROM
									maestros.Elemento_Sistema
								WHERE
									nIdElementoP = (SELECT nIdElemento FROM maestros.Elemento_Sistema WHERE sCodigo = 'ESTORDPAG')
									AND sCodigo = '2'
							)
						WHERE
							nIdOrdenPago = @nIdOrdenPago

						DECLARE	@sSerie VARCHAR(MAX)
						DECLARE	@nIdCorrelativo INT
						DECLARE	@nCorrelativo INT

						SELECT
							@sSerie = S.sCodigo
							,@nCorrelativo = C.nActual
							,@nIdCorrelativo = C.nIdCorrelativo
						FROM 
							maestros.Serie S
							INNER JOIN
							maestros.Correlativo C ON C.nIdSerie = S.nIdSerie AND C.bActivo = 1
						WHERE 
							S.nIdDocumento = @nIdTipoComprobante
							AND
							S.nIdCompania = @nIdCompania
							AND
							S.nIdUsuario = @nIdUsuario_crea
							AND
							C.nActual <= C.nHasta

						DECLARE @nValorInafecto DECIMAL(13,4) = NULL
						DECLARE @nValorNoGravado DECIMAL(13,4) = NULL

						IF @nIdTipoComprobante = (SELECT E.nIdElemento FROM maestros.Elemento_Sistema E INNER JOIN maestros.Elemento_Sistema EP ON EP.nIdElemento = E.nIdElementoP WHERE E.sCodigo = '4' AND EP.sCodigo = 'TIPDOCFOR')
						BEGIN
							SET @nValorInafecto = @nImporteOrdenP
							SET @nImporteSubTotalOP = NULL
						END
						ELSE
						BEGIN
							IF @bIGV <> 1
							BEGIN
								IF @sTipoIGVnoAplicado = 1
								BEGIN
									SET @nValorInafecto = @nImporteOrdenP
									SET @nImporteSubTotalOP = NULL
								END
								ELSE
								BEGIN
									SET @nValorNoGravado = @nImporteOrdenP
									SET @nImporteSubTotalOP = NULL
								END
							END
						END

						EXEC [contabilidad].[pa_comprobante] @nIdOrdenPago, @nIdTipoComprobante, @nIdCompania, @sSerie, @nCorrelativo, @nIdCliente,
																@sDNI, @sCE, @sRUC, @sNombreCompleto, @sDireccion, @sUbigeo, @nValorNoGravado, @nValorInafecto,
																@nImporteSubTotalOP, @nImporteIGVOP, @nImporteOrdenP, @nIdMonedaOrdenP, @nIdUsuario_crea,
																@bValido = @bValido OUTPUT, @nCod = @nCod OUTPUT, @sMsj = @sMsj OUTPUT

						IF(@bValido = 1)
						BEGIN
							UPDATE maestros.Correlativo
							SET
								nActual = @nCorrelativo + 1
							WHERE
								nIdCorrelativo = @nIdCorrelativo

							DECLARE @nIdComprobante INT
							SET @nIdComprobante = @nCod 

							DECLARE @tempDet TABLE (
								id					INT
								,nIdItem			INT
								,nIdCronograma		INT
								,sDescripcion		VARCHAR(MAX)
								,nCantidad			DECIMAL(13,4)
								,nValorUnitario		DECIMAL(13,4)
								,nValorSubtotal		DECIMAL(13,4)
								,nValorIgv			DECIMAL(13,4)
								,nValorTotal		DECIMAL(13,4)
								,bAfecto			BIT
							)

							INSERT INTO @tempDet
							SELECT
								nIdOrdenPagoDet
								,nIdItem
								,nIdCronograma
								,sDescripcion	
								,nCantidad		
								,nValorUnitario	
								,nValorSubtotal	
								,nValorIgv		
								,nValorTotal	
								,IIF(ISNULL(nValorIgv,0)>0,1,0)		
							FROM
								contabilidad.Orden_Pago_Det
							WHERE
								nIdOrdenPago = @nIdOrdenPago

							WHILE (SELECT COUNT(*) FROM @tempDet) > 0
							BEGIN
								DECLARE @id				INT
								DECLARE @nIdItem		INT
								DECLARE @sDescripcionD	VARCHAR(MAX)
								DECLARE @nCantidad		DECIMAL(13,4)
								DECLARE @nValorUnitario	DECIMAL(13,4)
								DECLARE @nValorSubtotal	DECIMAL(13,4)
								DECLARE @nValorIgv		DECIMAL(13,4)
								DECLARE @nValorTotal	DECIMAL(13,4)
								DECLARE @bAfecto		BIT

								SELECT TOP 1
									@id					= id				
									,@nIdItem			= nIdItem		
									,@sDescripcion		= sDescripcion	
									,@nCantidad			= nCantidad		
									,@nValorUnitario	= nValorUnitario	
									,@nValorSubtotal	= nValorSubtotal	
									,@nValorIgv			= nValorIgv		
									,@nValorTotal		= nValorTotal	
									,@bAfecto			= bAfecto
									,@nIdCronograma		= nIdCronograma
								FROM
									@tempDet

								IF @nIdTipoComprobante = (SELECT E.nIdElemento FROM maestros.Elemento_Sistema E INNER JOIN maestros.Elemento_Sistema EP ON EP.nIdElemento = E.nIdElementoP WHERE E.sCodigo = '4' AND EP.sCodigo = 'TIPDOCFOR')
								BEGIN
									SET @nValorInafecto = @nValorTotal
									SET @nValorSubtotal = NULL
								END
								ELSE
								BEGIN
									IF @bIGV <> 1
									BEGIN
										IF @sTipoIGVnoAplicado = 1
										BEGIN
											SET @nValorInafecto = @nValorTotal
											SET @nValorSubtotal = NULL
										END
										ELSE
										BEGIN
											SET @nValorNoGravado = @nValorTotal
											SET @nValorSubtotal = NULL
										END
									END
								END

								EXEC [contabilidad].[pa_comprobante];2 @nIdComprobante, @sDescripcion,
																	190, @nCantidad, @bAfecto, @nValorUnitario,  @nValorNoGravado, @nValorInafecto, @nValorSubtotal, @nValorIgv, @nValorTotal, @nIdMonedaOrdenP,
																	@nIdUsuario_crea, @bValido = @bValido OUTPUT, @nCod = @nCod OUTPUT, @sMsj = @sMsj OUTPUT

								IF(@bValido = 1)
								BEGIN
									IF(@nIdItem = 9)
									BEGIN
										UPDATE C
										SET
											C.nIdEstado = (SELECT E.nIdElemento FROM maestros.Elemento_Sistema E INNER JOIN maestros.Elemento_Sistema EP ON EP.nIdElemento = E.nIdElementoP WHERE E.sCodigo = '3' AND EP.sCodigo = 'ESTINMUEB')
										FROM
											contratos.Contrato C
										WHERE
											C.nIdContrato = @nIdContrato

										UPDATE L
										SET
											L.nIdEstado = (SELECT E.nIdElemento FROM maestros.Elemento_Sistema E INNER JOIN maestros.Elemento_Sistema EP ON EP.nIdElemento = E.nIdElementoP WHERE E.sCodigo = '3' AND EP.sCodigo = 'ESTINMUEB')
										FROM
											contratos.Contrato C
											INNER JOIN
											proyectos.Lote L ON L.nIdLote = C.nIdLote
										WHERE
											C.nIdContrato = @nIdContrato
									END

									IF(@nIdItem = 10)
									BEGIN
										DECLARE	@sSerieContrato VARCHAR(MAX)
										DECLARE	@nIdCorrelativoContrato INT
										DECLARE	@nCorrelativoContrato INT
						
										SELECT
											@sSerieContrato = S.sCodigo
											,@nIdCorrelativoContrato = C.nIdCorrelativo
											,@nCorrelativoContrato = C.nActual
										FROM
											maestros.Serie S
											INNER JOIN
											maestros.Correlativo C ON C.nIdSerie = S.nIdSerie AND C.bActivo = 1
										WHERE
											S.bActivo = 1
											AND
											S.nIdCompania = @nIdCompania
											AND
											S.nIdProyecto = @nIdProyecto
											AND
											S.nIdDocumento = (
												SELECT
													nIdElemento
												FROM
													maestros.Elemento_Sistema
												WHERE
													nIdElementoP = (SELECT nIdElemento FROM maestros.Elemento_Sistema WHERE sCodigo = 'TIPDOCFOR')
													AND sCodigo = '1'
											)

										UPDATE maestros.Correlativo
										SET
											nActual = @nCorrelativoContrato + 1
										WHERE
											nIdCorrelativo = @nIdCorrelativoContrato

										UPDATE C
										SET
											C.nIdEstado = (SELECT E.nIdElemento FROM maestros.Elemento_Sistema E INNER JOIN maestros.Elemento_Sistema EP ON EP.nIdElemento = E.nIdElementoP WHERE E.sCodigo = '4' AND EP.sCodigo = 'ESTINMUEB')
											,C.sCodigo = CONCAT(@sSerieContrato, '-', maestros.fn_Correlativo_8D(@nCorrelativoContrato))
											,C.dFechaVenta = GETDATE()
										FROM
											contratos.Contrato C
										WHERE
											C.nIdContrato = @nIdContrato

										UPDATE L
										SET
											L.nIdEstado = (SELECT E.nIdElemento FROM maestros.Elemento_Sistema E INNER JOIN maestros.Elemento_Sistema EP ON EP.nIdElemento = E.nIdElementoP WHERE E.sCodigo = '4' AND EP.sCodigo = 'ESTINMUEB')
										FROM
											contratos.Contrato C
											INNER JOIN
											proyectos.Lote L ON L.nIdLote = C.nIdLote
										WHERE
											C.nIdContrato = @nIdContrato

										DECLARE @nTipoFinanciamiento INT
										DECLARE @nCuotas INT
										DECLARE @nValorCuota INT 
										DECLARE @nIdCicloPago INT

										SELECT
											@nTipoFinanciamiento = TF.sCodigo 
											,@nCuotas = C.nCuotas
											,@nValorCuota = C.nValorCuota
											,@nIdCicloPago = C.nIdCicloPago
										FROM
											contratos.Contrato C
											INNER JOIN 
											maestros.Elemento_Sistema TF ON TF.nIdElemento = C.nIdCondicionPago
										WHERE
											nIdContrato = @nIdContrato

										IF(@nTipoFinanciamiento = '2')
										BEGIN							
											EXEC [contratos].[pa_cronograma];1 @nIdContrato, @nCuotas, @nIdMoneda, @nValorCuota, @nIdCicloPago, @nIdUsuario_crea, @bValido OUTPUT, @nCod OUTPUT, @sMsj OUTPUT
										END
									END

									IF(@nIdItem = 11)
									BEGIN
										UPDATE C
										SET
											C.nIdEstado = (SELECT E.nIdElemento FROM maestros.Elemento_Sistema E INNER JOIN maestros.Elemento_Sistema EP ON EP.nIdElemento = E.nIdElementoP WHERE E.sCodigo = '2' AND EP.sCodigo = 'ESTCRONOG')
											,C.dFechaPago = GETDATE()
										FROM
											contratos.Cronograma C
										WHERE
											C.nIdCronograma = @nIdCronograma
									END

									DELETE @tempDet WHERE id = @id
								END
								ELSE
								BEGIN
									BREAK ;
								END
							END
														
							IF(@bValido = 1)
							BEGIN
								
								EXEC [contabilidad].[pa_comprobante_cobranza] @nIdComprobante, @nIdCobranza,
																			@nIdUsuario_crea, @bValido = @bValido OUTPUT, @nCod = @nCod OUTPUT, @sMsj = @sMsj OUTPUT
							
								IF(@bValido = 1)
								BEGIN
									SET @nCod = @nIdComprobante
									SET @sMsj = 'Operación consumida.'
								END
								ELSE
								BEGIN
									SET @nCod = 0
									RAISERROR(@sMsj, 16, 1)
								END
							END
							ELSE
							BEGIN
								SET @nCod = 0
								RAISERROR(@sMsj, 16, 1)
							END
						END
						ELSE
						BEGIN
							SET @nCod = 0
							RAISERROR(@sMsj, 16, 1)
						END
					END
					ELSE
					BEGIN
						SET @nCod = 0
						RAISERROR(@sMsj, 16, 1)
					END
				END
				ELSE
				BEGIN
					SET @nCod = 0
					RAISERROR(@sMsj, 16, 1)
				END

			END TRY
			BEGIN CATCH
				SET @nCod = 0;
				SELECT @sMsj = ERROR_MESSAGE()  

				IF @@TRANCOUNT > 0  
					ROLLBACK TRANSACTION ConsumirOperacionBancaria;  
			END CATCH

		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION ConsumirOperacionBancaria;
	END
	
	SELECT @nCod AS nCod, @sMsj AS sMsj
END

GO
/****** Object:  NumberedStoredProcedure [bancos].[pa_operacion_bancaria];10    Script Date: 02/05/2025 18:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Author:		Mario Robles
-- Create date: 2024/11/13
-- Description:	BUSCAR OPERACION BANCARIA DISPONIBLE PARA EXTORNO RECAUDO BBVA POR REFERENCIA
ALTER PROCEDURE [bancos].[pa_operacion_bancaria];10 -- EXEC [bancos].[pa_operacion_bancaria];10 'OPV2-194'
	@sReferencia VARCHAR(MAX)
AS
BEGIN
	SELECT
		OB.nIdOperacionBancaria
		,P.nIdProyecto
		,P.sNombre AS sProyecto
		,OB.nIdCuenta
		,C.sNroCuenta
		,OB.nIdMoneda
		,M.sMoneda
		,M.sSimbolo
		,OB.sReferencia
		,OB.nMovimiento
		,OB.dFechaOperacion
		,OB.nImporte
		,OB.nITF
		,OB.nSaldo
		,OB.nIdEstado
		,E.sCodigo AS sCodigoEstado
		,E.sAbrev AS sEstado
		,OB.nIdAdjunto
		,A.sRutaFtp
		,OB.nIdUsuario_crea
		,OB.dFecha_crea
		,OB.nIdUsuario_mod
		,OB.dFecha_mod
	FROM
		bancos.Operacion_Bancaria OB
		INNER JOIN
		bancos.Cuenta C ON C.nIdCuenta = OB.nIdCuenta
		INNER JOIN
		maestros.Moneda M ON M.nIdMoneda = OB.nIdMoneda
		INNER JOIN
		proyectos.Proyecto P ON P.nIdProyecto = C.nIdProyecto
		INNER JOIN
		maestros.Elemento_Sistema E ON E.nIdElemento = OB.nIdEstado
		LEFT JOIN
		maestros.Adjunto A ON A.nIdAdjunto = OB.nIdAdjunto
	WHERE
		OB.sReferencia = @sReferencia
		AND
		E.sCodigo = '1'
END

GO
/****** Object:  NumberedStoredProcedure [bancos].[pa_operacion_bancaria];11    Script Date: 02/05/2025 18:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Author:		Mario Robles
-- Create date: 2024/11/13
-- Description:	ANULAR OPERACION BANCARIA DISPONIBLE POR EXTORNO RECAUDO BBVA
ALTER PROCEDURE [bancos].[pa_operacion_bancaria];11 -- EXEC [bancos].[pa_operacion_bancaria];11 1
	@nIdOperacionBancaria INT
	,@nIdOrdenPago INT
	,@nIdCronograma INT
AS
BEGIN
	DECLARE @nCod INT, @sMsj VARCHAR(MAX)
	DECLARE @bValido BIT = 1
	DECLARE @nCant INT

	IF(@bValido = 1)
	BEGIN
		SELECT
			@nCant = COUNT(*)
		FROM
			bancos.Operacion_Bancaria
		WHERE
			nIdOperacionBancaria = @nIdOperacionBancaria

		IF(@nCant = 0)
		BEGIN
			SET @bValido = 0
			SET @nCod = 0
			SET @sMsj = 'No existe la operacion bancaria indicada.'
		END
	END

	IF(@bValido = 1)
	BEGIN
		DECLARE @sCodigoEstado VARCHAR(MAX)
		DECLARE @sEstado VARCHAR(MAX)

		SELECT
			@sCodigoEstado = E.sCodigo
			,@sEstado  = E.sAbrev
		FROM
			bancos.Operacion_Bancaria OB
			INNER JOIN
			maestros.Elemento_Sistema E ON E.nIdElemento = OB.nIdEstado
		WHERE
			OB.nIdOperacionBancaria = @nIdOperacionBancaria
		
		IF(@sCodigoEstado <> '1')
		BEGIN
			SET @bValido = 0
			SET @nCod = 0
			SET @sMsj = 'La operación no se puede extornar debido a que esta en estado ' + ISNULL(@sEstado, 'NO IDENTIFICADO')
		END
	END
	
	IF(@bValido = 1)
	BEGIN
		BEGIN TRANSACTION UpdAnularOperacionBancaria
  		BEGIN TRY 
		
			UPDATE bancos.Operacion_Bancaria
			SET
				nIdEstado = (
							SELECT
								E.nIdElemento
							FROM 
								maestros.Elemento_Sistema E 
								INNER JOIN 
								maestros.Elemento_Sistema EP ON EP.nIdElemento = E.nIdElementoP
							WHERE
								EP.sCodigo = 'ESTOPEBAN'
								AND
								E.sCodigo = '3'
							)
				,nSaldo = 0
			WHERE
				nIdOperacionBancaria = @nIdOperacionBancaria
			
			IF(@nIdOrdenPago IS NOT NULL)
			BEGIN
				UPDATE
					contabilidad.Orden_Pago
				SET
					dFechaVencimiento = DATEADD(MINUTE, 30, dFechaVencimiento)
					,nIdEstado = (SELECT E.nIdElemento FROM maestros.Elemento_Sistema E INNER JOIN maestros.Elemento_Sistema EP ON EP.nIdElemento = E.nIdElementoP WHERE EP.sCodigo = 'ESTORDPAG' AND E.sCodigo = '1')
				WHERE
					nIdOrdenPago = @nIdOrdenPago
			END

			IF(@nIdCronograma IS NOT NULL)
			BEGIN
				UPDATE
					contratos.Cronograma
				SET
					dFechaPago = GETDATE()
					,nIdEstado = (SELECT E.nIdElemento FROM maestros.Elemento_Sistema E INNER JOIN maestros.Elemento_Sistema EP ON EP.nIdElemento = E.nIdElementoP WHERE EP.sCodigo = 'ESTCRONOG' AND E.sCodigo = '1')
				WHERE
					nIdCronograma = @nIdCronograma
			END
			
			SET @nCod = @nIdOperacionBancaria
			SET @sMsj = 'Operacion anulada.'

		END TRY
		BEGIN CATCH
			SET @nCod = 0;
			SELECT @sMsj = ERROR_MESSAGE()  

			IF @@TRANCOUNT > 0  
				ROLLBACK TRANSACTION UpdAnularOperacionBancaria;  
		END CATCH

		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION UpdAnularOperacionBancaria;  
	END

	SELECT @nCod AS nCod, @sMsj AS sMsj
END
