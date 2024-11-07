<%@page import="clases.MedioPagoPorCompra"%>
<%@page import="clases.Compra"%>
<%@page import="clases.Persona"%>
<%@page import="clases.MedioDePago"%>
<%@page import="java.util.List"%>

<%
 int elementosXPagina = 5;
 int pagina = 1;
 if (request.getParameter("pagina") != null) {
     pagina = Integer.parseInt(request.getParameter("pagina"));
 }
 int registroInicial = (pagina - 1) * elementosXPagina;
 int registroFinal = registroInicial + elementosXPagina;

 // Inicializaci�n de filtro
 String filtro = "";

 // Filtro por fecha de compra
 String chkFechaCompra = request.getParameter("chkFechaCompra");
 String inicio = "";
 String fin = "";
 if (chkFechaCompra != null) {
     chkFechaCompra = "checked";
     inicio = request.getParameter("inicio");
     fin = request.getParameter("fin");
     filtro = "(fechaCompra between '" + inicio + "' and '" + fin + "')";
 } else chkFechaCompra = "";

 // Filtro por n�mero de compra
 String chkCompra = request.getParameter("chkCompra");
 String idCompraDetalle = "";
 if (chkCompra != null) {
     chkCompra = "checked";
     idCompraDetalle = request.getParameter("idCompraDetalle");
     if (!filtro.equals("")) filtro += " and ";
     filtro += "idCompra like '%" + idCompraDetalle + "%'";
 } else chkCompra = "";

 // Filtro por proveedor
 String chkProveedor = request.getParameter("chkProveedor");
 String proveedor = "";
 if (chkProveedor != null) {
     chkProveedor = "checked";
     proveedor = request.getParameter("proveedor");
     if (!filtro.equals("")) filtro += " and ";
     filtro += "concat(identificacion,' - ',nombre) like '%" + proveedor + "%'";
 } else chkProveedor = "";

 // Filtro por medio de pago
 String chkMedioDePago = request.getParameter("chkMedioDePago");
 String idMedioDePago = "";
 if (chkMedioDePago != null) {
     chkMedioDePago = "checked";
     idMedioDePago = request.getParameter("idMedioDePago");
 } else chkMedioDePago = "";

 String lista = "";
 int totalLista = 0;
 int totalAbonado = 0;
 int totalSaldo = 0;

 // Obtener lista de compras con filtro y paginaci�n
 List<Compra> datos = Compra.getListaEnObjetos(filtro, "idCompra desc");
 int totalRegistros = datos.size();
 datos = Compra.getListaEnObjetos(filtro, "idCompra desc limit " + registroInicial + "," + elementosXPagina);

 // Generar lista de compras
 for (int i = 0; i < datos.size(); i++) {
     Compra compra = datos.get(i);
     List<MedioPagoPorCompra> datosMedioDePago = compra.getMediosDePago();
     boolean presentarRegistro = false;
     String listaMediosDePago = "<table>";
     for (int j = 0; j < datosMedioDePago.size(); j++) {
         MedioPagoPorCompra medioPagoCompra = datosMedioDePago.get(j);
         if (idMedioDePago.equals("") || idMedioDePago.equals(medioPagoCompra.getIdMedioPagoCompra())) presentarRegistro = true;
         listaMediosDePago += "<tr>";
         listaMediosDePago += "<td>" + medioPagoCompra.getNombreMedioDePago() + "</td>";
         listaMediosDePago += "<td align='right'>" + medioPagoCompra.getValor() + "</td>";
         listaMediosDePago += "</tr>";
     }
     listaMediosDePago += "</table>";
     if (presentarRegistro) {
         totalLista += compra.getTotal();
         totalAbonado += compra.getAbonado();
         totalSaldo += compra.getSaldo();
         lista += "<tr>";
         lista += "<td>" + compra.getFechaCompra() + "</td>";
         lista += "<td>" + compra.getIdCompra() + "</td>";
         lista += "<td>" + compra.getProveedor() + "</td>";
         lista += "<td>" + listaMediosDePago + "</td>";
         lista += "<td align='right'>" + compra.getTotal() + "</td>";
         lista += "<td align='right'>" + compra.getAbonado() + "</td>";
         lista += "<td align='right'>" + compra.getSaldo() + "</td>";
         lista += "<td>";
         lista += "<img src='presentacion/eliminar.png' title='Eliminar' onClick='eliminar(" + compra.getIdCompra() + ")'>";
         lista += "<img src='presentacion/detalle.png' title='Ver detalles' onClick='verDetalles(" + compra.getIdCompra() + ")'>";
         lista += "<img src='presentacion/pagos.png' title='Ver pagos pendientes' onClick='verPagos(" + compra.getIdCompra() + ")'>";
         lista += "</td>";
         lista += "</tr>";
     }
 }
 int numeroDePaginas = (int) Math.ceil((double)totalRegistros / elementosXPagina);
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lista de Compras</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        /* Estilo de encabezado centrado */
        .table-container h2 {
            text-align: center;
            color: #333;
            margin: 0;
            padding: 15px 0;
            font-size: 24px;
        }

        /* Expansi�n de contenedor de la tabla en toda la p�gina */
        .table-container {
            width: 100%;
            padding: 0;
            margin: 20px 0;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.15);
        }

        /* Estilo de la tabla */
        table.table {
            width: 100%;
            border-collapse: collapse;
        }

        /* Encabezado de las columnas de la tabla */
        .table thead th {
            background-color: #343a40;
            color: white;
            font-weight: bold;
            text-align: center;
        }

        /* Celdas de la tabla */
        .table tbody td {
            text-align: center;
            vertical-align: middle;
            padding: 10px;
        }

        /* Iconos dentro de los botones */
        .icono {
            width: 20px;
            height: 20px;
            margin-right: 5px;
        }
    </style>
</head>
<body class="bg-light">

<div class="container-fluid">
    <div class="table-container">
        <h2>COMPRAS</h2>
        <div class="form-container mb-3">
            <form name="formulario" method="post">
                <div class="form-row">
                    <div class="col">
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <div class="input-group-text">
                                    <input type="checkbox" name="chkFechaCompra" <%=chkFechaCompra%>> Fecha
                                </div>
                            </div>
                            desde <input type="date" name="inicio" value="<%=inicio%>" class="form-control">
                            hasta <input type="date" name="fin" value="<%=fin%>" class="form-control">
                        </div>
                    </div>
                    <div class="col">
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <div class="input-group-text">
                                    <input type="checkbox" name="chkCompra" <%=chkCompra%>> Compra
                                </div>
                            </div>
                            <input type="text" name="idCompraDetalle" value="<%=idCompraDetalle%>" class="form-control" placeholder="N�mero de compra">
                        </div>
                    </div>
                </div>
                <div class="form-row">
                    <div class="col">
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <div class="input-group-text">
                                    <input type="checkbox" name="chkProveedor" <%=chkProveedor%>> Proveedor
                                </div>
                            </div>
                            <input type="text" name="proveedor" id="proveedor" value="<%=proveedor%>" class="form-control" placeholder="Proveedor">
                        </div>
                    </div>
                     <div class="col">
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <div class="input-group-text">
                                    <input type="checkbox" name="chkMedioDePago" <%=chkMedioDePago%>> Medio de pago
                                </div>
                            </div>
                            <select name="idMedioDePago" class="form-control"><%=MedioDePago.getListaEnOptions(idMedioDePago)%></select>
                        </div>
                    </div>
                    <div class="col">
                        <button type="submit" class="btn btn-primary"><i class="fas fa-search"></i> Buscar</button>
                    </div>
                </div>
            </form>
        </div>
                             <center>
            P�gina <%=pagina%> de <%=numeroDePaginas%>,
            mostrando registros del <%=registroInicial + 1%> al <%=Math.min(registroFinal, totalRegistros)%> de un total de <%=totalRegistros%>
        </center>

        <div class="table-responsive">
            <table class="table table-hover table-bordered">
                <thead class="thead-dark">
                    <tr>
                        <th>Fecha Compra</th>
                        <th>N�mero Compra</th>
                        <th>Proveedor</th>
                        <th>Medio de pago</th>
                        <th>Total</th>
                        <th>Abonado</th>
                        <th>Saldo</th>
                        <th>
                            <a href="principal.jsp?CONTENIDO=comprasFormulario.jsp&accion=Adicionar" title="Adicionar">
                                <img src="presentacion/adicionar.png" class="icono" alt="Adicionar">
                            </a>
                            <img src="presentacion/excel.png" title="Generar reporte en excel" onclick="exportar('excel')" class="icono">
                            <img src="presentacion/word.png" title="Generar reporte en word" onclick='exportar("word")' class="icono">
                        </th>
                    </tr>
                </thead>
                <tbody>
                    <%=lista%>
                    <tr>
                        <th colspan="4">TOTAL</th>
                        <th align='right'><%=totalLista%></th>
                        <th align='right'><%=totalAbonado%></th>
                        <th align='right'><%=totalSaldo%></th>
                    </tr>
                </tbody>
            </table>
        </div>
       
        <div style="text-align: center;">
            <img src="presentacion/primero.png" onclick="cambiarPagina('primero')"/>
            <img src="presentacion/anterior.png" onclick="cambiarPagina('anterior')"/>
            <input type="text" name="pagina" value="<%=pagina%>" size="2" onchange="cambiarPagina('especifico')"/>
            <img src="presentacion/siguiente.png" onclick="cambiarPagina('siguiente')"/>
            <img src="presentacion/ultimo.png" onclick="cambiarPagina('ultimo')"/>
        </div>
    </div>
</div>

<script type="text/javascript">
    var personas = <%=Persona.getListaEnArregloJs("tipo='P'", null)%>
    $("#proveedor").autocomplete({
        source: personas
    }); 
    function cambiarPagina(pagina){
        paginaActual=parseInt(document.formulario.pagina.value);
        switch(pagina){
            case "primero": pagina=1; break;
            case "anterior": pagina=paginaActual-1; break;
            case "especifico": pagina=paginaActual; break;
            case "siguiente": pagina=paginaActual+1; break;
            case "ultimo": pagina=<%=numeroDePaginas%>; break;
        }
        document.formulario.pagina.value=pagina;
        document.formulario.submit();
    }

    function eliminar(idCompra){
        respuesta=confirm("Realmente desea eliminar la compra "+idCompra+" con sus detalles y pagos?");
        if(respuesta){
            document.location="principal.jsp?CONTENIDO=comprasActualizar.jsp&accion=Eliminar&idCompra="+idCompra;
        }
    }
     function verPagos(idCompra){
        document.location="principal.jsp?CONTENIDO=pagosCompras.jsp&idCompra="+idCompra;
    }
    function verDetalles(idCompra){
        document.location="principal.jsp?CONTENIDO=comprasDetalles.jsp&idCompra="+idCompra;
    }

    function exportar(formato){
        window.open("comprasExportar.jsp?formato="+formato+"&filtro=<%=filtro%>");
    }    
</script>

</body>
</html>