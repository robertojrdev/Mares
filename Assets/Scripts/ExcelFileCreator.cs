using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class ExcelFileCreator
{
    public static bool IsSaving { get; private set; } = true;

    public static IEnumerator Create(ExcelData data, string name, string path, bool openOnSave = false)
    {
        IsSaving = true;

        string directory = path + @"\QUESTIONARIO";
        path = directory + @"\" + name + ".csv";

        //El archivo existe? lo BORRAMOS
        if (File.Exists(path))
        {
            File.Delete(path);
        }

        if (!Directory.Exists(directory))
            Directory.CreateDirectory(directory);

        var sr = File.CreateText(path);

        sr.WriteLine(data.data);

        FileInfo fInfo = new FileInfo(path);
        fInfo.IsReadOnly = false;

        //Cerrar
        sr.Close();

        Debug.Log(path);

        yield return new WaitForSeconds(0.5f);//Esperamos para estar seguros que escriba el archivo

        //Abrimos archivo recien creado
        if(openOnSave)
            Application.OpenURL(path);

        IsSaving = false;
    }
}

public class ExcelData
{
    public string data { get; private set; }

    public void AddCell(string value)
    {
        data += value + ";";
    }

    public void AddLine()
    {
        data += "\n";
    }

    public void Append(bool addLine, params ExcelData[] data)
    {
        foreach (var item in data)
        {
            if (addLine)
                AddLine();

            this.data += item.data;
        }
    }
}
