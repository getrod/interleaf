package com.example.interleaf;

import android.graphics.Bitmap;
import android.util.Log;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.opencv.core.Core;
import org.opencv.core.CvException;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.MatOfPoint;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Scalar;
import org.opencv.core.Size;
import org.opencv.imgcodecs.Imgcodecs;
import org.opencv.imgproc.Imgproc;
import org.opencv.imgproc.Moments;
import org.opencv.android.Utils;

public class CardMaker {

    static final String TAG = "OpenCV";

    private static Mat fileToMat(String path) {
        Log.d(TAG, "Inside fileToMat method. Path string is: " + path);
        Imgcodecs imageCodecs = new Imgcodecs();
        try {
            //Read the image from file location into Mat object
            Mat img = imageCodecs.imread(path);
            return img;
        } catch (Exception e){
            System.out.println("Wrong image path probably: " + e.getMessage());
            return null;
        }
    }

    public static Mat getIndexCard (String path, String picSetting){

        Log.d(TAG, "Inside getIndexCard method");
        Mat img = fileToMat(path);
        Mat finalImg = fileToMat(path);
        Log.d(TAG, "fileToMat method was successful: " + img.toString());

        try {

            Log.d(TAG, "Before convert method");
            //img.convertTo(img, 0);
            Imgproc.cvtColor(img, img, Imgproc.COLOR_RGB2GRAY);
            Log.d(TAG, "After convert method");

            //Create hieght and width variables for ease
            int width = img.cols();
            int hieght = img.rows();

            Log.d(TAG, "After width and hieght " + width + " " + hieght);

            //Apply Gausian Blur to the image
            Imgproc.GaussianBlur(img, img, new Size(5, 5), 0);

            Log.d(TAG, "After Blur effect");

            //Apply Otsu Threshold to image
            Imgproc.threshold(img, img, 0, 255, Imgproc.THRESH_OTSU);

            Log.d(TAG, "After threshold");

            //Find Contours of the processed image
            List<MatOfPoint> contours = new ArrayList<>();
            Imgproc.findContours(img, contours, new Mat(), Imgproc.RETR_TREE, Imgproc.CHAIN_APPROX_SIMPLE);

            Log.d(TAG, "After find contours");

            //Approximate each polylines of the contours
            //Only polylines with four points get added to markerCandidates
            List<MatOfPoint> markerCandidates = new ArrayList<>();
            for (int i = 0; i < contours.size(); i++) {
                MatOfPoint2f curve = new MatOfPoint2f(contours.get(i).toArray());
                double epsilon = 0.05 * Imgproc.arcLength(curve, true);
                MatOfPoint2f approxCurv = new MatOfPoint2f();
                Imgproc.approxPolyDP(curve, approxCurv, epsilon, true);

                double area = Imgproc.contourArea(approxCurv);
                //System.out.println(area);
                if (approxCurv.toArray().length == 4 && area > 500) {
                    markerCandidates.add(new MatOfPoint(approxCurv.toArray()));
                }
            }

            Log.d(TAG, "After marker candidates");

            //Find the center of each marker, and create new MatOfPoint from it
            Point[] centerPnts = new Point[4];
            for (int i = 0; i < centerPnts.length; i++) {
                List<MatOfPoint> validMarkers = findValidMarkers(img, markerCandidates, DictTag.CORNER_TAGS6X6[i], 6);
                //Find the center of that marker
                Point center = centerPoint(validMarkers.get(0));
                //Add it to Points[]
                centerPnts[i] = center;
            }

            List<MatOfPoint> centerImage = new ArrayList<>();
            centerImage.add(new MatOfPoint(centerPnts));

            Log.d(TAG, "The center points: " + Arrays.toString(centerPnts));

//            ///////////////Debug///////////////////
//            Imgproc.drawContours(img, centerImage, -1, new Scalar(0,0,0));
//            return img;

            //Warp the image so that its just the center
            Size aspectRatio = new Size(1920, 1080);

            Point[] matrix = {
                    new Point(0, 0),
                    new Point(aspectRatio.width, 0),
                    new Point(aspectRatio.width, aspectRatio.height),
                    new Point(0, aspectRatio.height)
            };

            MatOfPoint2f pnt2 = new MatOfPoint2f(matrix);
            MatOfPoint2f pnt1 = new MatOfPoint2f(centerImage.get(0).toArray());
            pnt1 = reorderRectPoints(pnt1);
            Mat M = Imgproc.getPerspectiveTransform(pnt1, pnt2);
            Mat indexCard = new Mat();
            indexCard.create(0, 0, 0);

            if (picSetting.equals("d")) {
                System.out.println("Defult Photo");
                Imgproc.warpPerspective(img, indexCard, M, aspectRatio);
            }
            if (picSetting.equals("g")) {
                System.out.println("Greyscale Photo");
                Imgproc.warpPerspective(finalImg, indexCard, M, aspectRatio);
                Imgproc.cvtColor(indexCard, indexCard, Imgproc.COLOR_RGB2GRAY);
            }
            if (picSetting.equals("c")) {
                System.out.println("Greyscale Photo");
                Imgproc.warpPerspective(finalImg, indexCard, M, aspectRatio);
            }


            //Imgproc.warpPerspective(finalImg, indexCard, M, aspectRatio);

            //Imgproc.cvtColor(indexCard, indexCard, Imgproc.COLOR_RGB2GRAY);
            //Imgproc.GaussianBlur(indexCard, indexCard, new Size(5, 5), 0);
            //Imgproc.adaptiveThreshold(indexCard, indexCard,255,Imgproc.ADAPTIVE_THRESH_GAUSSIAN_C,Imgproc.THRESH_BINARY,15,40);
            //Imgproc.adaptiveThreshold(indexCard, indexCard,255,Imgproc.ADAPTIVE_THRESH_MEAN_C,Imgproc.THRESH_BINARY,19,30);
            Log.d(TAG, "End of index card method.");

            return indexCard;
        } catch (Exception e){
            Log.d(TAG, "Cannot detect aruco markers: " + e.toString());
            //System.out.println("Cannot detect aruco markers: " + e.getMessage());
            return null;
        }
    }

    private static Bitmap matToBitmap(Mat mat){
        Bitmap newBitmap = Bitmap.createBitmap(mat.cols(), mat.rows(),
                Bitmap.Config.ARGB_8888);
        Utils.matToBitmap(mat, newBitmap);
        return newBitmap;
    }

    public static boolean createIndexCard(String path, String picSetting){
        Imgcodecs imageCodecs = new Imgcodecs();
        Mat card = getIndexCard(path, picSetting);
        if (card == null){
            return false;
        } else {
            Log.d(TAG, "About to write index card image to path");
            boolean write = imageCodecs.imwrite(path, card);
            Log.d(TAG, "After writing index card image to path: " + write);
            return true;
        }
    }

    private static MatOfPoint2f reorderRectPoints(MatOfPoint2f pnts){
        //First: top left
        //Second: top right
        //Third: bottom right
        //Forth: bottom left

        MatOfPoint2f rect;

        //Add and subtract the x and y for each point
        double[] add = new double[4];
        double[] diff = new double[4];
        for (int i = 0; i < pnts.toArray().length; i++){
            add[i] = pnts.toArray()[i].x + pnts.toArray()[i].y;
            diff[i] = pnts.toArray()[i].x - pnts.toArray()[i].y;
        }

        //Find the max and min value of the result
        double maxAdd = add[0];
        double minAdd = add[0];
        int maxAddIdx = 0;
        int minAddIdx = 0;
        double maxDiff = diff[0];
        double minDiff = diff[0];
        int maxDiffIdx = 0;
        int minDiffIdx = 0;

        for (int i = 1; i < add.length; i++){
            if(add[i] > maxAdd){
                maxAdd = add[i];
                maxAddIdx = i;
            }
            if(diff[i] > maxDiff){
                maxDiff = diff[i];
                maxDiffIdx = i;
            }
            if(add[i] < minAdd){
                minAdd = add[i];
                minAddIdx = i;
            }
            if(diff[i] < minDiff){
                minDiff = diff[i];
                minDiffIdx = i;
            }
        }

        //Arrange the points in the way described
        Point[] reArranged = {
                pnts.toArray()[minAddIdx],
                pnts.toArray()[maxDiffIdx],
                pnts.toArray()[maxAddIdx],
                pnts.toArray()[minDiffIdx]
        };

        rect = new MatOfPoint2f(reArranged);

        return rect;
    }

    private static int[][] tagToBinary2dArray(Mat tag, int minWhitePxlCount, int tagWidth){
        //Binarize the tag
        Imgproc.threshold(tag, tag, 0, 255, Imgproc.THRESH_OTSU);

        //Count the black and white pixel in cell
        //determine if cell is 0 or 1
        int[][] result = new int[tagWidth][tagWidth];
        for (int i = 0; i < result.length; i++){
            for (int j = 0; j < result.length; j++){
                Mat cell = tag.submat((i*10), (10+(i*10)), (j*10), (10+(j*10)));
                Mat m = new Mat();
                Core.extractChannel(cell, m, 0);
                int n = Core.countNonZero(m);
                //If at least (# of threshold) white pixels in a cell, that is a 1,
                //else 0
                if (n >= minWhitePxlCount){
                    result[i][j] = 1;
                } else {
                    result[i][j] = 0;
                }
                //System.out.print(result[i][j] + ", ");
            }
            //System.out.println("");
        }
        return result;
    }

    private static boolean isMarkerTag(int[][] tag, int[][] dict, int maxError){
        int errorAmount = 0;
        boolean result = false;
        for(int i = 0; i < tag.length; i++){
            for(int j = 0; j < tag.length; j++){
                if(tag[i][j] != dict[i][j]){
                    errorAmount++;
                }
            }
        }

        if(errorAmount <= maxError){
            result = true;
        }

        return result;
    }

    private static List<MatOfPoint> findValidMarkers(Mat src, List<MatOfPoint> markerCandidates, int[][] dict, int tagWidth){

        List<MatOfPoint> validMarkers = new ArrayList<>();

        int p = tagWidth*10;

        Point[] matrix = {
                new Point(0, 0),
                new Point(p,0),
                new Point(p, p),
                new Point(0, p)
        };

        MatOfPoint2f pnt2 = new MatOfPoint2f(matrix);

        for (int i = 0; i < markerCandidates.size(); i++){
            MatOfPoint2f pnt1 = new MatOfPoint2f(markerCandidates.get(i).toArray());
            pnt1 = reorderRectPoints(pnt1);
            Mat M = Imgproc.getPerspectiveTransform(pnt1, pnt2);
            Mat tagCandidate = new Mat();
            tagCandidate.create(0, 0, 0);
            Imgproc.warpPerspective(src, tagCandidate, M, new Size(p,p));
            int[][]tag = tagToBinary2dArray(tagCandidate, 50, tagWidth);
            boolean valid = isMarkerTag(tag, dict, 3);

            if(valid == true){
                validMarkers.add(markerCandidates.get(i));
            }
        }

        return validMarkers;
    }

    private static Point centerPoint(MatOfPoint mat){
        Moments m = Imgproc.moments(mat);
        int Cx = (int)(m.m10/m.m00);
        int Cy = (int)(m.m01/m.m00);
        Point center = new Point(Cx,Cy);
        return center;
    }
}
