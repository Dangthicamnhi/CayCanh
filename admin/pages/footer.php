<footer class="py-5 bg-dark">
    <div class="container">
        <p class="m-0 text-center text-white" style="color: #a1e6a1 !important">Rainbow Graden là nhóm các bạn trẻ năng động được thành lập từ môn Phát triển ứng dụng web. Với mới mong muốn mang đến cuộc sống nhiều màu xanh hơn. </p>
    </div>
    <!-- /.container -->

</footer>
<!-- /#wrapper -->

<!-- jQuery -->
<script src="../vendor/jquery/jquery.min.js"></script>

<!-- Bootstrap Core JavaScript -->
<script src="../vendor/bootstrap/js/bootstrap.min.js"></script>

<!-- Metis Menu Plugin JavaScript -->
<script src="../vendor/metisMenu/metisMenu.min.js"></script>

<!-- Morris Charts JavaScript -->
<script src="../vendor/raphael/raphael.min.js"></script>
<script src="../vendor/morrisjs/morris.min.js"></script>
<script src="../data/morris-data.js"></script>

<!-- DataTables JavaScript -->
<script src="../vendor/datatables/js/jquery.dataTables.min.js"></script>
<script src="../vendor/datatables/js/dataTables.semanticui.js"></script>
<script src="../vendor/datatables/js/jquery.dataTables.js"></script>
<script src="../vendor/datatables-plugins/dataTables.bootstrap.min.js"></script>
<script src="../vendor/datatables-responsive/dataTables.responsive.js"></script>
<script src="../vendor/morrisjs/morris.min.js"></script>

<!-- Custom Theme JavaScript -->

<script src="../dist/js/sb-admin-2.js"></script>
<!-- Custom Theme JavaScript -->
<script src="../dist/js/sb-admin-2.js"></script>
<script type="text/javascript">
    Morris.Bar({
        element: 'bar-tt',
        data: [{
                y: '2020',
                a: 100,
                b: 90
            },
            {
                y: '2021',
                a: 75,
                b: 65
            },
            {
                y: '2022',
                a: 50,
                b: 40
            },
            {
                y: '2023',
                a: 75,
                b: 65
            },
            {
                y: '2024',
                a: 50,
                b: 70
            }
        ],
        xkey: 'y',
        ykeys: ['a', 'b'],
        labels: ['Series A', 'Series B']
    });
</script>>
<script type="text/javascript">
    Morris.Donut({
        element: 'morris-donut-chart',
        data: [
            <?php
            $sqlChar = "SELECT p.category, sum( d.quantity * p.price) tprice FROM cart_detail d JOIN product p ON d.id_product = p.id GROUP BY p.category ";
            $CharCart = $db->executeQuery($sqlChar);
            $i = 0;
            $ttMor[] = "100";
            $ttMor[] = "100";
            $ttMor[] = "100";
            /*while($row=mysqli_fetch_assoc($CharCart))
    {
       $ttMor[]=$row["tprice"];
   }*/
            ?> {
                label: "Download Sales",
                value: 12
            },
            {
                label: "In-Store Sales",
                value: 30
            },
            {
                label: "Mail-Order Sales",
                value: 20
            }
        ]
    });
</script>
<!-- Page-Level Demo Scripts - Tables - Use for reference -->
<script>
    $(document).ready(function() {
        $('#dataTables-example').DataTable({
            responsive: true
        });
    });
</script>




</body>

</html>
</body>

</html>