

import javax.swing.ImageIcon;
import java.awt.Image;

public class img {
    public Image imgLoading(String filepath) {
        ImageIcon icon = new ImageIcon(filepath);
        return icon.getImage();
    }
    public ImageIcon IconLoading(String filepath) {
        ImageIcon icon = new ImageIcon(filepath);
        return icon;
    }
    public Image ScaleImage(Image img, int width, int height) {
        Image scaled = img.getScaledInstance(width, height, Image.SCALE_SMOOTH);
        return scaled;
    }
}
